'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { Skeleton } from '@/components/ui/skeleton';
import { Plus, Edit, Trash2, Shield, Users } from 'lucide-react';
import { toast } from 'sonner';
import { usePermissions } from '@/contexts/permissions-context';

export default function RolesPage() {
  const queryClient = useQueryClient();
  const { canAccess } = usePermissions();
  const [selectedRole, setSelectedRole] = useState<any>(null);
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [roleType, setRoleType] = useState<'PLATFORM_OWNER' | 'MERCHANT'>('PLATFORM_OWNER');

  // Form state
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [hierarchyLevel, setHierarchyLevel] = useState('2');
  const [selectedFeatures, setSelectedFeatures] = useState<string[]>([]);
  const [featureActions, setFeatureActions] = useState<Record<string, string[]>>({});

  const { data: roles, isLoading } = useQuery({
    queryKey: ['roles', roleType],
    queryFn: async () => {
      const res = await apiClient.get(`/roles?type=${roleType}`);
      return res.data.data || [];
    },
  });

  const { data: features } = useQuery({
    queryKey: ['features', roleType],
    queryFn: async () => {
      const res = await apiClient.get(`/features?type=${roleType}`);
      return res.data.data || [];
    },
  });

  const createMutation = useMutation({
    mutationFn: async (data: any) => {
      const res = await apiClient.post('/roles', data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      setIsCreateDialogOpen(false);
      resetForm();
      toast.success('Role created successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to create role');
    },
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: string; data: any }) => {
      const res = await apiClient.put(`/roles/${id}`, data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      setIsEditDialogOpen(false);
      resetForm();
      toast.success('Role updated successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to update role');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const res = await apiClient.delete(`/roles/${id}`);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      toast.success('Role deleted successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to delete role');
    },
  });

  const resetForm = () => {
    setName('');
    setDescription('');
    setHierarchyLevel('2');
    setSelectedFeatures([]);
    setFeatureActions({});
    setSelectedRole(null);
  };

  const handleCreate = () => {
    if (!name.trim()) {
      toast.error('Role name is required');
      return;
    }

    createMutation.mutate({
      name,
      description,
      type: roleType,
      hierarchyLevel: parseInt(hierarchyLevel, 10),
      featureIds: selectedFeatures,
      featureActions,
    });
  };

  const handleEdit = (role: any) => {
    setSelectedRole(role);
    setName(role.name);
    setDescription(role.description || '');
    setHierarchyLevel(role.hierarchyLevel.toString());
    setSelectedFeatures(role.features?.map((f: any) => f.id) || []);
    const actionsMap: Record<string, string[]> = {};
    role.features?.forEach((rf: any) => {
      if (rf.actions && rf.actions.length > 0) {
        actionsMap[rf.id] = rf.actions;
      }
    });
    setFeatureActions(actionsMap);
    setIsEditDialogOpen(true);
  };

  const handleUpdate = () => {
    if (!selectedRole || !name.trim()) {
      toast.error('Role name is required');
      return;
    }

    updateMutation.mutate({
      id: selectedRole.id,
      data: {
        name,
        description,
        hierarchyLevel: parseInt(hierarchyLevel, 10),
        featureIds: selectedFeatures,
        featureActions,
      },
    });
  };

  const handleDelete = (role: any) => {
    if (confirm(`Are you sure you want to delete the role "${role.name}"?`)) {
      deleteMutation.mutate(role.id);
    }
  };

  const toggleFeature = (featureId: string) => {
    if (selectedFeatures.includes(featureId)) {
      setSelectedFeatures(selectedFeatures.filter((id) => id !== featureId));
      const newActions = { ...featureActions };
      delete newActions[featureId];
      setFeatureActions(newActions);
    } else {
      setSelectedFeatures([...selectedFeatures, featureId]);
    }
  };

  const toggleFeatureAction = (featureId: string, action: string) => {
    const currentActions = featureActions[featureId] || [];
    if (currentActions.includes(action)) {
      setFeatureActions({
        ...featureActions,
        [featureId]: currentActions.filter((a) => a !== action),
      });
    } else {
      setFeatureActions({
        ...featureActions,
        [featureId]: [...currentActions, action],
      });
    }
  };

  if (!canAccess('roles.view')) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Roles</h1>
          <p className="text-muted-foreground">You do not have permission to view this page</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Roles Management</h1>
          <p className="text-muted-foreground">Create and manage roles with feature-based permissions</p>
        </div>
        <div className="flex items-center gap-2">
          <Select value={roleType} onValueChange={(value: any) => setRoleType(value)}>
            <SelectTrigger className="w-[200px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="PLATFORM_OWNER">Platform Owner Roles</SelectItem>
              <SelectItem value="MERCHANT">Merchant Roles</SelectItem>
            </SelectContent>
          </Select>
          {canAccess('roles.create') && (
            <Dialog
              open={isCreateDialogOpen}
              onOpenChange={(open) => {
                setIsCreateDialogOpen(open);
                if (!open) resetForm();
              }}
            >
              <DialogTrigger asChild>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Create Role
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                  <DialogTitle>Create New Role</DialogTitle>
                  <DialogDescription>
                    Create a new role and assign features to it
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Role Name</Label>
                    <Input
                      id="name"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      placeholder="e.g., Super Admin, Auditor"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="description">Description</Label>
                    <Textarea
                      id="description"
                      value={description}
                      onChange={(e) => setDescription(e.target.value)}
                      placeholder="Role description"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="hierarchyLevel">Hierarchy Level</Label>
                    <Select value={hierarchyLevel} onValueChange={setHierarchyLevel}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="3">3 - Super Admin</SelectItem>
                        <SelectItem value="2">2 - Admin</SelectItem>
                        <SelectItem value="1">1 - Auditor</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label>Features</Label>
                    <div className="border rounded-md p-4 max-h-64 overflow-y-auto space-y-2">
                      {features?.map((feature: any) => (
                        <div key={feature.id} className="flex items-start gap-2">
                          <input
                            type="checkbox"
                            checked={selectedFeatures.includes(feature.id)}
                            onChange={() => toggleFeature(feature.id)}
                            className="mt-1"
                          />
                          <div className="flex-1">
                            <div className="font-medium">{feature.name}</div>
                            <div className="text-sm text-muted-foreground">{feature.description}</div>
                            {selectedFeatures.includes(feature.id) && !feature.isPageLevel && (
                              <div className="mt-2 space-x-2">
                                {['view', 'create', 'edit', 'delete'].map((action) => (
                                  <label key={action} className="inline-flex items-center gap-1 text-sm">
                                    <input
                                      type="checkbox"
                                      checked={featureActions[feature.id]?.includes(action) || false}
                                      onChange={() => toggleFeatureAction(feature.id, action)}
                                    />
                                    {action}
                                  </label>
                                ))}
                              </div>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                  <Button onClick={handleCreate} disabled={createMutation.isPending} className="w-full">
                    {createMutation.isPending ? 'Creating...' : 'Create Role'}
                  </Button>
                </div>
              </DialogContent>
            </Dialog>
          )}
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>{roleType === 'PLATFORM_OWNER' ? 'Platform Owner' : 'Merchant'} Roles</CardTitle>
          <CardDescription>Manage roles and their feature permissions</CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <Skeleton key={i} className="h-16 w-full" />
              ))}
            </div>
          ) : roles && roles.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Role Name</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Hierarchy</TableHead>
                  <TableHead>Features</TableHead>
                  <TableHead>Users</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {roles.map((role: any) => (
                  <TableRow key={role.id}>
                    <TableCell>
                      <div>
                        <div className="font-medium">{role.name}</div>
                        {role.description && (
                          <div className="text-sm text-muted-foreground">{role.description}</div>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{role.type}</Badge>
                    </TableCell>
                    <TableCell>
                      <Badge>
                        Level {role.hierarchyLevel}
                        {role.hierarchyLevel === 3 && ' - Super Admin'}
                        {role.hierarchyLevel === 2 && ' - Admin'}
                        {role.hierarchyLevel === 1 && ' - Auditor'}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <Shield className="h-4 w-4 text-muted-foreground" />
                        <span>{role.features?.length || 0} features</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <Users className="h-4 w-4 text-muted-foreground" />
                        <span>{role.userCount || 0} users</span>
                      </div>
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex justify-end gap-2">
                        {canAccess('roles.edit') && (
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => handleEdit(role)}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                        )}
                        {canAccess('roles.delete') && !role.isSystemRole && (
                          <Button
                            size="sm"
                            variant="destructive"
                            onClick={() => handleDelete(role)}
                            disabled={deleteMutation.isPending}
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <div className="text-center py-12">
              <Shield className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No roles found</p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Edit Dialog */}
      <Dialog
        open={isEditDialogOpen}
        onOpenChange={(open) => {
          setIsEditDialogOpen(open);
          if (!open) resetForm();
        }}
      >
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Edit Role</DialogTitle>
            <DialogDescription>
              Update role information and feature permissions
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="edit-name">Role Name</Label>
              <Input
                id="edit-name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g., Super Admin, Auditor"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-description">Description</Label>
              <Textarea
                id="edit-description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Role description"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-hierarchyLevel">Hierarchy Level</Label>
              <Select value={hierarchyLevel} onValueChange={setHierarchyLevel}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="3">3 - Super Admin</SelectItem>
                  <SelectItem value="2">2 - Admin</SelectItem>
                  <SelectItem value="1">1 - Auditor</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Features</Label>
              <div className="border rounded-md p-4 max-h-64 overflow-y-auto space-y-2">
                {features?.map((feature: any) => (
                  <div key={feature.id} className="flex items-start gap-2">
                    <input
                      type="checkbox"
                      checked={selectedFeatures.includes(feature.id)}
                      onChange={() => toggleFeature(feature.id)}
                      className="mt-1"
                    />
                    <div className="flex-1">
                      <div className="font-medium">{feature.name}</div>
                      <div className="text-sm text-muted-foreground">{feature.description}</div>
                      {selectedFeatures.includes(feature.id) && !feature.isPageLevel && (
                        <div className="mt-2 space-x-2">
                          {['view', 'create', 'edit', 'delete'].map((action) => (
                            <label key={action} className="inline-flex items-center gap-1 text-sm">
                              <input
                                type="checkbox"
                                checked={featureActions[feature.id]?.includes(action) || false}
                                onChange={() => toggleFeatureAction(feature.id, action)}
                              />
                              {action}
                            </label>
                          ))}
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <Button onClick={handleUpdate} disabled={updateMutation.isPending} className="w-full">
              {updateMutation.isPending ? 'Updating...' : 'Update Role'}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

